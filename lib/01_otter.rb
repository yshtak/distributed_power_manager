#= RabbitMQを使ったメッセージの送信と受信を司るクラス
#Author:: Takuya Yoshimura
#Versions:: 1.0
#Copyright:: (C) Itolab, 2013. All rights reserved.
#License:: Ruby License
#== 利用方法
# 
module Otter 
 require 'bunny'
 require 'awesome_print'
 require 'uuidtools'
 def send_message exchange
  
 end

 def recieve_message

 end
 
 #
 #== rabbitMQと接続してくれるクラス
 # MailmanではAMQPのExchangeのタイプを指定できて
 # 指定されたタイプ及び宛先を動的に変更できる。
 class Mailman
  attr_reader :config, :id, :queues

  def initialize cfg={}
   @config={ # 初期設定
    rabbitmq: {host: 'localhost'}, # RabbitMQのHostname
    routing_key: 'default', # ルート
    exchange: 'direct',
    auto_delete: true, # オートデリート
    id: UUIDTools::UUID.random_create.to_s # アドレス 
   }.merge(cfg)
   @providers = {} # Providersの初期化
   @queues = {}
   @id = @config[:id] 
   begin
    @bunny = Bunny.new @config[:rabbitmq]
    @bunny.start
    @channel = @bunny.create_channel
    self.set_exchange @config[:exchange]
   rescue => e
    ap e.message
    ap e.backtrace
   end
  end

  #
  #=== メッセージの発行
  # メッセージを発行する。発行する相手は設定したExchange。
  # _id_: providerのidでキューへのrouting_key
  # _msg_: 送るメッセージ 
  def send_message msg
   case @exchange.type
   when :direct
    @exchange.publish(msg, :routing_key => @id)
   when :fanout
    @exchange.publish(msg)
   when :topic
    @exchange.publish(msg, :routing_key => @id)
   end
  end

  #
  #=== 自分がチェックしている情報提供者の一覧を取得
  # _return_: 中身はexchangerのidとexchangerのhashが返ってくる 
  #
  def my_providers
   @providers
  end

  #
  #
  #
  def recieve_message message
   ap "recieve_message: #{message}"
  end

  #
  #
  #
  def set_exchange type
    case type
    when 'direct'
     @exchange = @channel.direct(@id)
    when 'fanout'
     @exchange = @channel.fanout(@id)
    when 'topic'
     @exchange = @channel.topic(@id)
    end
  end

  #
  #=== Queueの作成
  # _qname_: Queueの場所の名前（RoutingKeyの指定）．
  # 
  def create_queue qname
   q = @channel.queue(qname, :auto_delete => @config[:auto_delete]).bind(@exchange, :routing_key => @id)
   @queues.store(qname, q)
   q.subscribe do |delivery_info, properties, payload|
    self.recieve_message(payload) 
   end
  end
 end

end
