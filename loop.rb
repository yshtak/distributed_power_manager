# coding: utf-8

require './lib/01_otter'

test = Otter::Mailman.new({id: 'test'})

test.create_queue 'madoka'

loop do
 test.send_message 'ああああ'
 sleep 1
end
