# Iris Stem Plot - Lollipop Chart
#
# Demonstrates plot_stem for discrete data visualization.

require "../src/crysda-plot"

iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Stem Plot"
puts "========================="

# Get first 20 samples
sample = iris.take(20).add_row_number("id")

plot = sample.plot_stem("id", "Petal.Length")
plot.title("Petal Length (First 20 Samples)")
plot.xlabel("Sample ID")
plot.size(800, 600)
plot.save("examples/iris_stem.png")

puts "Saved: examples/iris_stem.png"
