# Iris Regression - Scatter with Linear Fit
#
# Demonstrates plot_regression for visualizing linear
# relationships with R² annotation.

require "../src/crysda-plot"

iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Regression Analysis"
puts "==================================="

plot = iris.plot_regression("Petal.Length", "Petal.Width")
plot.title("Petal Length vs Width (Linear Regression)")
plot.size(800, 600)
plot.save("examples/iris_regression.png")

puts "Saved: examples/iris_regression.png"
