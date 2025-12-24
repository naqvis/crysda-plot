# Iris Q-Q Plot - Normality Check
#
# Demonstrates plot_qq for checking if data follows normal distribution.

require "../src/crysda-plot"

iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Q-Q Plot"
puts "========================"

plot = iris.plot_qq("Sepal.Length")
plot.size(800, 600)
plot.save("examples/iris_qq.png")

puts "Saved: examples/iris_qq.png"
