#!/usr/bin/env ruby

require '../ldap'
require 'httparty'
require 'csv'

USER_ACTIVE_DAYS = ENV.fetch('USER_ACTIVE_DAYS', 0).to_i
MAILBOX_USED_DAYS = ENV.fetch('MAILBOX_USED_DAYS', 30).to_i
ELASTIC_PASS = ENV.fetch('ELASTIC_PASS')

print "Extracting all active users with a mailbox in ECS and active#{ " since #{USER_ACTIVE_DAYS} ago" if USER_ACTIVE_DAYS > 0}..."

expire = LDAP.to_ad_ts Time.now - USER_ACTIVE_DAYS*86400
filter = Net::LDAP::Filter.ge('accountExpires', expire)
filter &= Net::LDAP::Filter.eq('mail', '*')
filter &= Net::LDAP::Filter.ne('extensionAttribute6', 'MigratedToO365-*')

users = LDAP.connection.search attributes: %w( samaccountname mail accountexpires division ),
  filter: filter, base: 'dc=ifad,dc=org', scope: Net::LDAP::SearchScope_WholeSubtree

puts "#{users.size} mailboxes found"

print "Querying for all mailboxes accessed in the last #{MAILBOX_USED_DAYS} days... "

used = HTTParty.post "https://elastic:#{ELASTIC_PASS}@es.ifad.org:9201/exchange/_search", body: {
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {"range": {"@timestamp": { "gt": "now-#{MAILBOX_USED_DAYS}d"}}},
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

user_division = users.inject({}) {|h, u| h.update(u[:samaccountname].first => u[:division].first) }

ts = Time.now.strftime '%Y-%m-%d-%H%M%S'

File.write "#{ts}-users.csv", CSV.generate {|csv|
	csv << %w( LANID division mail )
  users.each {|u| csv << [ u[:samaccountname].first, u[:division].first, u[:mail].first ] }
}

lanids = users.map {|u| u[:samaccountname].first }

File.write "#{ts}-used.csv", CSV.generate {|csv|
	csv << %w( LANID division )
  used.each {|u| csv << [ u, user_division[u] ] }
}

File.write "#{ts}-unused.csv", CSV.generate {|csv|
	csv << %w( LANID division )
	(lanids - used).each {|u| csv << [ u, user_division[u] ]}
}
