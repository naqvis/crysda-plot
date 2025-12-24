# Sleep Duration Distribution - Histogram
#
# This example demonstrates:
# - Histogram with custom bin count
# - Data filtering for clean analysis
# - Distribution visualization
#
# Visualizes the distribution of total sleep hours across mammal species.

require "../src/crysda-plot"

# Load mammal sleep dataset
msleep = Crysda.read_csv("examples/data/msleep.csv")

puts "Analyzing sleep duration distribution across #{msleep.num_row} mammal species"
puts ""

# Basic statistics
sleep_col = msleep["sleep_total"]
puts "Sleep duration stats:"
puts "  Min: #{sleep_col.min(true)} hours"
puts "  Max: #{sleep_col.max(true)} hours"
puts "  Mean: #{sleep_col.mean(true).round(2)} hours"
puts ""

# Create histogram of sleep duration
plot = msleep.plot_histogram("sleep_total", bins: 12)

plot.title("Distribution of Sleep Duration Across Mammals")
plot.xlabel("Total Sleep (hours)")
plot.ylabel("Number of Species")
plot.xrange(0.0, 22.0)
plot.grid.show

plot.save("examples/sleep_histogram.png")
puts "Saved: examples/sleep_histogram.png"
