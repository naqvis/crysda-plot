# Sleep Area Chart - Stacked Time Composition
#
# Demonstrates plot_area for visualizing composition over categories.

require "../src/crysda-plot"

# Create simple time series data for area chart
df = Crysda.dataframe_of("month", "product_a", "product_b", "product_c").values(
  1, 10, 20, 15,
  2, 15, 25, 18,
  3, 20, 22, 25,
  4, 25, 30, 22,
  5, 30, 28, 30,
  6, 28, 35, 28
)

puts "Area Chart - Sales Composition"
puts "==============================="

plot = df.plot_area("month", "product_a", "product_b", "product_c")
plot.title("Monthly Sales by Product")
plot.xlabel("Month")
plot.ylabel("Sales")
plot.size(800, 600)
plot.save("examples/sleep_area.png")

puts "Saved: examples/sleep_area.png"
