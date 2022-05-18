defmodule MudWeb.ViewHelpers do

  def user_local_time_string(nil, date) do
    month = String.pad_leading(Integer.to_string(date.month), 2, "0")
    day = String.pad_leading(Integer.to_string(date.day), 2, "0")
    hour = String.pad_leading(Integer.to_string(date.hour), 2, "0")
    minute = String.pad_leading(Integer.to_string(date.minute), 2, "0")

    "#{date.year}/#{month}/#{day} #{hour}:#{minute}"
  end

  def user_local_time_string(user, time) do
    date = DateTime.shift_zone!(time, user.timezone)
    month = String.pad_leading(Integer.to_string(date.month), 2, "0")
    day = String.pad_leading(Integer.to_string(date.day), 2, "0")
    hour = String.pad_leading(Integer.to_string(date.hour), 2, "0")
    minute = String.pad_leading(Integer.to_string(date.minute), 2, "0")

    "#{date.year}/#{month}/#{day} #{hour}:#{minute}"
  end
end
