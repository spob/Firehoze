Factory.sequence :group do |n|
  "group#{n}"
end

Factory.define :group do |f|
  f.name { Factory.next(:group) }
  f.description "This is a longer description"
  f.private false
end