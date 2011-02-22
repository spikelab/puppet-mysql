# hash a string as mysql's "PASSWORD()" function would do it
# mysql treats an empty password differently and does not generate an hash for it
require 'digest/sha1'

module Puppet::Parser::Functions
	newfunction(:mysql_password, :type => :rvalue) do |args|
                hash = ''
                if args[0] != ''
                    hash = '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(args[0])).upcase
                end
                hash
	end
end

