namespace Data
{
    public interface ICalculator
    {
        decimal Divide(decimal number1, decimal number2);

        decimal Multiply(decimal number1, decimal number2);

        decimal Subtract(decimal number1, decimal number2);

        decimal Sum(decimal number1, decimal number2);
    }
}
