using Data;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace MSTest
{
    [TestClass]
    public class RealTest
    {
        private readonly ICalculator _calculator = new Calculator();

        [TestMethod]
        public void Divide()
        {
            Assert.AreEqual(100, _calculator.Divide(1000, 10));
        }

        [ExpectedException(typeof(DivideByZeroException))]
        [TestMethod]
        public void DivideByZeroException()
        {
            _calculator.Divide(1000, 0);
        }

        [TestMethod]
        public void Multiply()
        {
            Assert.AreEqual(100, _calculator.Multiply(5, 20));
        }

        [TestMethod]
        public void Subtract()
        {
            Assert.AreEqual(100, _calculator.Subtract(150, 50));
        }

        [TestMethod]
        public void Sum()
        {
            Assert.AreEqual(100, _calculator.Sum(40, 60));
        }
    }
}
