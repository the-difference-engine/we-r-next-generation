require 'bcrypt'

def createPasswordHash (password)
  return BCrypt::Password.create(password)
end

def checkPassword (passwordHash, password)
  correctPass = BCrypt::Password.new(passwordHash)
  return correctPass.is_password?(password)
end
