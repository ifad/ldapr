# vim: ft=ruby
Ifad::God.unicorn do |w|
  w.uid = 'ldapr'
  w.gid = 'ruby'
  w.env = {
    'RAILS_RELATIVE_URL_ROOT' => '/l',
    'RAILS_ENV' => 'staging'
  }
end
