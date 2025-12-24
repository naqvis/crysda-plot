# Iris Correlation Matrix
#
# This example demonstrates:
# - Correlation matrix visualization
# - Automatic numeric column detection
# - Heatmap-style display with correlation values
#
# Shows correlations between all numeric measurements in the Iris dataset.

require "../src/crysda-plot"

# Load the Iris dataset
iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Numeric Columns Correlation"
puts "==========================================="
puts ""

# Select only numeric columns for correlation
numeric_iris = iris.select("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

# Create correlation matrix plot
plot = numeric_iris.plot_correlation
plot.title("Iris Measurements Correlation Matrix")

plot.save("examples/iris_correlation.png")
puts "Saved: examples/iris_correlation.png"
