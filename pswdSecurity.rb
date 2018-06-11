require 'bcrypt'

def createPasswordHash (password)
  return BCrypt::Password.create(password)
end

def checkPassword (correctPassword, password)

end
