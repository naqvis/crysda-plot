# Iris Pairplot - Scatter Matrix
#
# Demonstrates plot_pairplot for visualizing relationships
# between all numeric column pairs.

require "../src/crysda-plot"

iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Pairplot"
puts "========================"

# Select only numeric columns for pairplot
numeric_iris = iris.select("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

fig = numeric_iris.plot_pairplot
fig.title("Iris Numeric Features")
fig.size(1000, 1000)
fig.save("examples/iris_pairplot.png")

puts "Saved: examples/iris_pairplot.png"
