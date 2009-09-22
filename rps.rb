class Player
  attr_accessor :name, :object
  def play(*args)
    puts "#{name} played #{args.inspect}"
  end
  
  def initialize(options)
    @name = options[:name] if options[:name]
  end
  
  def throws(*args)
    @object = args.first
    self
  end
  
  def method_missing(*args)
    method_name = args.first
    if %w{rock? paper? scissors?}.include?(method_name.to_s)
      @object == method_name.to_s.sub('?', '')
    else
      super(*args)
    end
  end
end

class RPS
  attr_accessor :current_player, :current_object
  def self.play(*args)
    yield
    play_with # once more!
    resolve
  end
  
  def self.play_as(player)
    @current_player = player
  end
  
  def self.play_with(object=nil)
    if @current_object
      store @current_player.throws(@current_object)
    end
    @current_object = object
  end
  
  def self.store(player)
    @players ||= []
    @players << player
  end
  
  def self.resolve
    p1, p2 = @players
    puts "#{p1.name} plays #{p1.object}"
    puts "#{p2.name} plays #{p2.object}"
    winner = paper_beats_rock || rock_beats_scissors || scissors_beats_paper
    puts winner ? " >> #{winner.name} wins!" : " >> It's a tie!"
    @players = []
  end
  
  def self.paper_beats_rock
    winner = @players.detect { |p| p.paper? }
    @players.detect { |p| p.rock? } ? winner : false
  end
  
  def self.rock_beats_scissors
    winner = @players.detect { |p| p.rock? }
    @players.detect { |p| p.scissors? } ? winner : false
  end
  
  def self.scissors_beats_paper
    winner = @players.detect { |p| p.scissors? }
    @players.detect { |p| p.paper? } ? winner : false
  end
  
  def self.same_play?
    @players.first.object == @players.last.object
  end
  
  def self.played!(object)
    puts "#{@current_player.inspect}"
  end
  
  def self.players=(names)
    @player_names = names
  end
  
  def self.playing_with?(object)
    return false unless @player_names
    @player_names.include?(object.to_s.downcase)
  end
end

def players(p1, p2)
  RPS.players = p1, p2
end

def method_missing(method_name, object=nil)
  if [:paper, :rock, :scissors].include? method_name
    method_name.to_s
  elsif RPS.playing_with?(method_name)
    RPS.play_as(Player.new(:name => method_name.to_s))
  elsif [:throws, :shoots].include?(method_name)
    RPS.play_with(object)
  else
    method_name.to_s
  # else # debug!
  #   super 
  end
end

players sam, ola

RPS.play {
  Sam throws paper
  Ola shoots rock
}

RPS.play {
  Sam throws paper
  Ola shoots scissors
}

RPS.play {
  Sam throws rock
  Ola shoots rock
}

players dave, adam
RPS.play {
  dave throws rock
  adam shoots scissors
}
