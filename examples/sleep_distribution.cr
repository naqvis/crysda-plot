# Sleep Distribution - Histogram with KDE
#
# Demonstrates plot_distribution for visualizing
# data distribution with kernel density estimation.

require "../src/crysda-plot"

sleep = Crysda.read_csv("examples/data/msleep.csv")

puts "Sleep Dataset - Distribution Analysis"
puts "======================================"

plot = sleep.plot_distribution("sleep_total", bins: 15)
plot.title("Total Sleep Distribution with KDE")
plot.size(800, 600)
plot.save("examples/sleep_distribution.png")

puts "Saved: examples/sleep_distribution.png"
