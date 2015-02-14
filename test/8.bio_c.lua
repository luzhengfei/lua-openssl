local openssl = require'openssl'
local csr,bio,ssl = openssl.csr,openssl.bio, openssl.ssl
local sslctx = require'sslctx'

host = arg[1] or "127.0.0.1"; --only ip
port = arg[2] or "8383";
loop = arg[3] and tonumber(arg[3]) or 100
local params = {
   mode = "client",
   protocol = "tlsv1",
   key = "luasec/certs/clientAkey.pem",
   certificate = "luasec/certs/clientA.pem",
   cafile = "luasec/certs/rootA.pem",
   verify = {"peer", "fail_if_no_peer_cert"},
   options = {"all", "no_sslv2"},
}

local ctx = assert(sslctx.new(params))
--[[
ctx:verify_mode({'peer'},function(arg) 

      print(arg)
      --do some check
      for k,v in pairs(arg) do
            print(k,v)
      end

      return true --return false will fail ssh handshake
end)
--]]
print(string.format('CONNECT to %s:%s with %s',host,port,ctx))

function mk_connection(host,port,i)
  local cli = assert(ctx:bio(host..':'..port))
  if(cli) then
      assert(cli:handshake())
      ---[[
    if(i%2==2) then
        assert(cli:handshake())
    else
        assert(cli:connect())
    end
    --]]
    s = 'aaa'
    io.write('.')
    for j=1,100 do
          assert(cli:write(s))
          assert(cli:read())
    end
    cli:shutdown()
    cli:close()
    cli = nil
    collectgarbage()
  end
  openssl.error(true)
end

for i=1,loop do
  mk_connection(host,port,i)
end

os.exit(1)
