# Sleep Grouped Bar - Side by Side Comparison
#
# Demonstrates plot_grouped_bar for comparing
# multiple metrics across categories.

require "../src/crysda-plot"

sleep = Crysda.read_csv("examples/data/msleep.csv")

puts "Sleep Dataset - Grouped Bar Chart"
puts "=================================="

# Aggregate sleep metrics by vore (diet type)
summary = sleep
  .filter { |df| df["vore"].matching { |v| !v.nil? && !v.to_s.empty? } }
  .group_by("vore")
  .summarize(
    "avg_sleep".with { |df| df["sleep_total"].mean(true) },
    "avg_awake".with { |df| df["awake"].mean(true) }
  )

plot = summary.plot_grouped_bar("vore", "avg_sleep", "avg_awake")
plot.title("Sleep vs Awake Hours by Diet Type")
plot.ylabel("Hours")
plot.size(800, 600)
plot.save("examples/sleep_grouped_bar.png")

puts "Saved: examples/sleep_grouped_bar.png"
