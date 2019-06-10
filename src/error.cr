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

  # Creates a new error.
  # Usualy, don't have to be used directly.
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

  def to_s(io : IO) : Nil
    io << message
  end

  def inspect(io : IO) : Nil
    io << message << " (" << self.class << ')'
    backtrace io
  end

  def backtrace(io : IO) : Nil
    @parent.try &.backtrace io
    io << "\n   from " << @file << ':' << @line << " in '"
    if @type != "<Program>"
      io << @type
      io << (@receiver ? '#' : '.')
    end
    io << @method << '\''
  end

  # Throws an error with a message, object, method, file and line location.
  # Optionally adds a parent `Error`.
  macro throw(message = nil, parent_error = nil)
    return {{@type}}.new(\{{@type.stringify}}, {{@def.receiver.stringify.empty?}}, {{@def.name.stringify}}, {{message}}, __FILE__, __LINE__, {{parent_error.id}})
  end
end
