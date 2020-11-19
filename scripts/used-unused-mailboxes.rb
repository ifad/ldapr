#!/usr/bin/env ruby

require 'net/ldap'
require '../ldap'
require 'httparty'
require 'active_support/json'
require 'csv'

ACTIVE_DAYS = ENV.fetch('ACTIVE_DAYS', 0)
ELASTIC_PASS = ENV.fetch('ELASTIC_PASS')

print "Extracting all active users with a mailbox in ECS and active#{ " since #{ACTIVE_DAYS} ago" if ACTIVE_DAYS > 0}..."

expire = LDAP.to_ad_ts Time.now - ACTIVE_DAYS*86400
filter = Net::LDAP::Filter.ge('accountExpires', expire)
filter &= Net::LDAP::Filter.eq('mail', '*')
filter &= Net::LDAP::Filter.ne('extensionAttribute6', 'MigratedToO365-*')

users = LDAP.connection.search attributes: %w( samaccountname mail accountexpires employeeid ),
  filter: filter, base: 'dc=ifad,dc=org', scope: Net::LDAP::SearchScope_WholeSubtree

puts "#{users.size} mailboxes found"

print "Querying for all mailboxes accessed in the last 3 months... "

used = HTTParty.post "https://elastic:#{ELASTIC_PASS}@es.ifad.org:9201/exchange/_search", body: {
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {"range": {"@timestamp": { "gt": "now-3M"}}},
        { "exists": {"field": "person.employee_id"} },
        { "query_string": {"query": "http_request:(ews owa ecp OAB rpc exchange.asmx activesync api)"}}
      ]
    }
  },
  "aggs": {
    "by_user": {
      "terms": {
        "field": "user.keyword",
        "size": 10000
      }
    }
  }
}.to_json, headers: {'content-type': 'application/json'}

used = used.as_json['aggregations']['by_user']['buckets'].map {|b| b['key']}

puts "#{used.size} usages found"


ts = Time.now.strftime '%Y-%m-%d-%H%M%S'

File.write "#{ts}-users.csv", CSV.generate {|csv|
	csv << %w( LANID mail employeeid )
	users.each {|u| csv << [ u[:samaccountname].first, u[:mail].first, u[:employeeid].first ] }
}

lanids = users.map {|u| u[:samaccountname].first }

File.write "#{ts}-used.csv", CSV.generate {|csv|
	csv << %w( LANID )
  used.each {|u| csv << [ u ] }
}

File.write "#{ts}-unused.csv", CSV.generate {|csv|
	csv << %w( LANID )
	(lanids - used).each {|u| csv << [ u ]}
}
