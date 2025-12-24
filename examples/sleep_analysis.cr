# Mammal Sleep Analysis - Multi-Series Comparison
#
# This example demonstrates:
# - Loading CSV with missing values (NA handling)
# - Data filtering and aggregation with Crysda
# - Multi-series line plot comparing groups
# - Bar chart for categorical comparisons
# - Histogram for distribution analysis
#
# The msleep dataset contains sleep data for 83 mammal species including
# total sleep time, REM sleep, body weight, and brain weight.

require "../src/crysda-plot"

# Load mammal sleep dataset
msleep = Crysda.read_csv("examples/data/msleep.csv")

puts "Mammal Sleep Dataset Overview:"
puts "=============================="
msleep.schema
puts ""

# Analyze sleep patterns by diet type (vore)
# Filter out rows with missing vore or sleep data, then aggregate
sleep_by_diet = msleep
  .filter { |df| df["vore"].matching { |v| !v.empty? && v != "NA" } }
  .filter { |df| df["sleep_total"].is_not_na }
  .group_by("vore")
  .summarize(
    "avg_sleep".with { |df| df["sleep_total"].mean(true) },
    "avg_rem".with { |df| df["sleep_rem"].mean(true) },
    "count".with { |df| df.num_row }
  )
  .sort_by("avg_sleep")

puts "Average Sleep by Diet Type:"
sleep_by_diet.print
puts ""

# Create bar chart: Average total sleep by diet type
plot = sleep_by_diet.plot_bar("vore", "avg_sleep")
plot.title("Average Sleep Duration by Diet Type")
plot.ylabel("Hours of Sleep")
plot.xlabel("Diet Type")
plot.yrange(0.0, 16.0)
plot.grid.show

plot.save("examples/sleep_by_diet.png")
puts "Saved: examples/sleep_by_diet.png"
