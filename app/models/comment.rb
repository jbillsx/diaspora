class Comment
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks

  
  xml_accessor :text
  xml_accessor :person, :as => Person
  xml_accessor :post_id
  
  key :text, String
  timestamps!
  
  key :post_id, ObjectId
  belongs_to :post, :class_name => "Post"
  
  key :person_id, ObjectId
  belongs_to :person, :class_name => "Person"
  
  after_save :send_people_comments_on_my_posts
  after_save :send_to_view
  

  def ==(other)
    (self.message == other.message) && (self.person.email == other.person.email)
  end
  
  
  protected
  
  def send_people_comments_on_my_posts
    if User.owner.mine?(self.post) && !(self.person.is_a? User)
      self.push_to(self.post.people_with_permissions)
    end
  end
  
  
  def send_to_view
    SocketsController.new.outgoing(self)
  end
end
