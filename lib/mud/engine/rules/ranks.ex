defmodule Mud.Engine.Rules.Ranks do
  @moduledoc """
  Methods for calculating ranks.
  """
  @one_minute_in_seconds 60
  @one_day_in_seconds 86400
  @three_and_half_days_in_seconds 302_400
  @one_week_in_seconds 604_800
  @two_weeks_in_seconds 1_209_600
  @one_month_in_seconds 2_628_000
  @one_year_in_seconds @one_month_in_seconds * 12
  @b (:math.sqrt(61) - 5) / 18
  @c (23 - 3 * :math.sqrt(61)) / 90

  @doc """
  Given the number of activity points for a skill, each point representing one second of time, return a skill rank.

  Skill progression follows the pattern:
  1 Rank = 60 seconds
  10 Ranks = 1 day
  25 Ranks = 3.5 days
  50 Ranks = 7 days
  75 Ranks = 14 days
  100 Ranks = 1 month
  200 Ranks = 3 months
  300 Ranks = 6 months
  400 Ranks = 1 year
  +100 ranks per year after
  """
  @spec rank(number) :: float
  def rank(points) when points <= @one_minute_in_seconds do
    (points / 60) |> normalize()
  end

  @points_per_rank_2_10 (@one_day_in_seconds - @one_minute_in_seconds) / 9
  def rank(points) when points > @one_minute_in_seconds and points <= @one_day_in_seconds do
    ((points - @one_minute_in_seconds) / @points_per_rank_2_10 + 1) |> normalize()
  end

  @points_per_rank_11_25 (@three_and_half_days_in_seconds - @one_day_in_seconds) / 15
  def rank(points)
      when points > @one_day_in_seconds and points <= @three_and_half_days_in_seconds do
    ((points - @one_day_in_seconds) / @points_per_rank_11_25 + 10) |> normalize()
  end

  @points_per_rank_26_50 (@one_week_in_seconds - @three_and_half_days_in_seconds) / 25
  def rank(points)
      when points > @three_and_half_days_in_seconds and points <= @one_week_in_seconds do
    ((points - @three_and_half_days_in_seconds) / @points_per_rank_26_50 + 25) |> normalize()
  end

  @points_per_rank_51_75 (@two_weeks_in_seconds - @one_week_in_seconds) / 25
  def rank(points) when points > @one_week_in_seconds and points <= @two_weeks_in_seconds do
    ((points - @one_week_in_seconds) / @points_per_rank_51_75 + 50) |> normalize()
  end

  @points_per_rank_76_100 (@one_month_in_seconds - @two_weeks_in_seconds) / 25
  def rank(points) when points > @two_weeks_in_seconds and points <= @one_month_in_seconds do
    ((points - @two_weeks_in_seconds) / @points_per_rank_76_100 + 75) |> normalize()
  end

  def rank(points) when points > @one_month_in_seconds and points <= @one_year_in_seconds do
    points = points / @one_month_in_seconds

    (100 +
       100 * :math.log((1 + @b * points + @c * (points * points)) / (1 + @b + @c)) /
         :math.log((1 + 3 * @b + 9 * @c) / (1 + @b + @c)))
    |> normalize()
  end

  def rank(points) when points > @one_year_in_seconds do
    points = points / @one_month_in_seconds

    (100 * points / 12 + 300) |> normalize()
  end

  defp normalize(ranks) do
    Float.round(ranks, 2)
  end
end
