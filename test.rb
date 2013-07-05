# coding:utf-8
require './lib/01_otter'

ma = Otter::Mailman.new({id: 'madoka'})
ho = Otter::Mailman.new({id: 'homura'})

ma.create_queue('homura')
ho.create_queue('madoka')

sleep
