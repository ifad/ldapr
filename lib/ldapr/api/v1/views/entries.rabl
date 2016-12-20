collection @entries, root: 'entries', object_root: 'entry'

[
  :dn, :objectclass, :cn, :sn, :givenname, :distinguishedname, :instancetype, :whencreated, :whenchanged,
  :displayname, :usncreated, :usnchanged, :name, :useraccountcontrol, :badpwdcount, :codepage,
  :countrycode, :badpasswordtime, :lastlogoff, :lastlogon, :pwdlastset, :primarygroupid,
  :accountexpires, :logoncount, :samaccountname, :samaccounttype, :userprincipalname, :objectcategory, :mail
].each do |attr|
  node(attr) do |entry|
    value = entry.send(attr)
    value.respond_to?(:join) ? value.join(", ") : attr
  end
end
