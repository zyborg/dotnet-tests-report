namespace Data
{
    public sealed class Calculator : ICalculator
    {
        public decimal Divide(decimal number1, decimal number2) => number1 / number2;

        public decimal Multiply(decimal number1, decimal number2) => number1 * number2;

        public decimal Subtract(decimal number1, decimal number2) => number1 - number2;

        public decimal Sum(decimal number1, decimal number2) => number1 + number2;
    }
}
