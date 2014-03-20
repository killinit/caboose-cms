
class Caboose::Setting < ActiveRecord::Base
  self.table_name = "settings"
  attr_accessible :name, :value
  
  def self.value_for(name)
    s = self.where(:name => name).first
    return '' if s.nil?
    return s.value
  end      
end
