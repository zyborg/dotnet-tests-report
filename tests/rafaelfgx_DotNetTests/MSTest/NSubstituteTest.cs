using Data;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using NSubstitute;
using System;

namespace MSTest
{
    [TestClass]
    public class NSubstituteTest
    {
        [TestMethod]
        public void Divide()
        {
            var calculator = Substitute.For<ICalculator>();

            calculator.Divide(Arg.Any<decimal>(), Arg.Any<decimal>()).Returns(100);

            Assert.AreEqual(100, calculator.Divide(1000, 10));
        }

        [TestMethod]
        [ExpectedException(typeof(DivideByZeroException))]
        public void DivideByZeroException()
        {
            var calculator = Substitute.For<ICalculator>();

            calculator.Divide(1000, 0).Returns(_ => throw new DivideByZeroException());

            calculator.Divide(1000, 0);
        }

        [TestMethod]
        public void Multiply()
        {
            var calculator = Substitute.For<ICalculator>();

            calculator.Multiply(Arg.Any<decimal>(), Arg.Any<decimal>()).Returns(100);

            Assert.AreEqual(100, calculator.Multiply(5, 20));
        }

        [TestMethod]
        public void Subtract()
        {
            var calculator = Substitute.For<ICalculator>();

            calculator.Subtract(Arg.Any<decimal>(), Arg.Any<decimal>()).Returns(100);

            Assert.AreEqual(100, calculator.Subtract(150, 50));
        }

        [TestMethod]
        public void Sum()
        {
            var calculator = Substitute.For<ICalculator>();

            calculator.Sum(Arg.Any<decimal>(), Arg.Any<decimal>()).Returns(100);

            Assert.AreEqual(100, calculator.Sum(40, 60));
        }

        [TestMethod]
        public void SumParameters()
        {
            var calculator = Substitute.For<ICalculator>();

            calculator.Sum(0, 0).Returns(0);

            calculator.Sum(40, 60).Returns(100);

            Assert.AreEqual(0, calculator.Sum(0, 0));

            Assert.AreEqual(100, calculator.Sum(40, 60));
        }
    }
}
