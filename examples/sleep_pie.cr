# Sleep Pie Chart - Diet Distribution
#
# Demonstrates plot_pie for showing proportions.

require "../src/crysda-plot"

sleep = Crysda.read_csv("examples/data/msleep.csv")

puts "Sleep Dataset - Pie Chart"
puts "=========================="

# Count animals by diet type
diet_counts = sleep
  .filter { |df| df["vore"].matching { |v| !v.nil? && !v.to_s.empty? } }
  .count("vore")

plot = diet_counts.plot_pie("vore", "n")
plot.title("Mammals by Diet Type")
plot.size(800, 800)
plot.save("examples/sleep_pie.png")

puts "Saved: examples/sleep_pie.png"
