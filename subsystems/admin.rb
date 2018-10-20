require 'pry'

# A module for dispatching administrative tasks
module AdminCommands
  # Drops admins to a debugger when they invoke !pry
  def admin_pry(event)
    binding.pry
  end
end
