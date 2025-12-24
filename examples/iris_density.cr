# Iris Density Plot - KDE Comparison
#
# Demonstrates plot_density for comparing distributions.

require "../src/crysda-plot"

iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Density Plot"
puts "============================"

plot = iris.plot_density("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
plot.title("Iris Feature Distributions")
plot.size(800, 600)
plot.save("examples/iris_density.png")

puts "Saved: examples/iris_density.png"
