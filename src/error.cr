class Error
  CURRENT_DIR = begin
    dir = Process::INITIAL_PWD
    dir.ends_with?(File::SEPARATOR) ? dir : dir + File::SEPARATOR
  end

  getter type : String,
    receiver : Bool,
    method : String,
    message : String?,
    file : String,
    line : Int32,
    parent : Error?

  def initialize(
    @type : String,
    @receiver : Bool,
    @method : String,
    message : String? = nil,
    file : String = __FILE__,
    @line : Int32 = __LINE__,
    @parent : Error? = nil
  )
    @message = message if message
    @file = file.lchop CURRENT_DIR
  end

  def to_s(io : IO)
    io << message
  end

  def inspect(io : IO)
    io << message << " (" << self.class << ')'
    backtrace io
  end

  def backtrace(io : IO)
    @parent.try &.backtrace io
    io << "\n   from " << @file << ':' << @line << " in '"
    if @type != "<Program>"
      io << @type
      io << (@receiver ? '#' : '.')
    end
    io << @method << '\''
  end

  macro throw(message = nil)
    return {{@type}}.new(\{{@type.stringify}}, {{@def.receiver.stringify.empty?}}, {{@def.name.stringify}}, {{message}}, __FILE__, __LINE__)
  end
end

macro throw(error, message = nil)
  return {{error}}.class.new({{@type.stringify}}, {{@def.receiver.stringify.empty?}}, {{@def.name.stringify}}, {{message}}, __FILE__, __LINE__, {{error.id}})
end
