Factory.define :video do |f|
  f.title "The video title"
  f.description "This is a longer description"
  f.association :author, :factory => :user
end