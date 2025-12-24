# Sleep Metrics Comparison - Box Plot
#
# This example demonstrates:
# - Box plot comparing multiple numeric columns
# - Visualizing distribution spread and quartiles
# - Comparing different sleep metrics side by side
#
# Compares total sleep vs REM sleep vs awake time distributions.

require "../src/crysda-plot"

# Load mammal sleep dataset
msleep = Crysda.read_csv("examples/data/msleep.csv")

# Filter for complete sleep data
complete = msleep
  .filter { |df| df["sleep_total"].is_not_na }
  .filter { |df| df["sleep_rem"].is_not_na }
  .filter { |df| df["awake"].is_not_na }

puts "Mammals with complete sleep metrics: #{complete.num_row}"
puts ""

# Show summary stats for each metric
["sleep_total", "sleep_rem", "awake"].each do |col|
  data = complete[col]
  puts "#{col}:"
  puts "  Median: #{data.median(true).round(2)} hours"
  puts "  Range: #{data.min(true)} - #{data.max(true)} hours"
end
puts ""

# Create box plot comparing the three metrics
plot = complete.plot_box("sleep_total", "sleep_rem", "awake")

plot.title("Comparison of Sleep Metrics Across Mammals")
plot.ylabel("Hours")
plot.yrange(0.0, 24.0)
plot.grid.show

plot.save("examples/sleep_boxplot.png")
puts "Saved: examples/sleep_boxplot.png"
