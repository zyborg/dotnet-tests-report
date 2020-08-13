using Data;
using FakeItEasy;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace MSTest
{
    [TestClass]
    public class FakeItEasyTest
    {
        [TestMethod]
        public void Divide()
        {
            var calculator = A.Fake<ICalculator>();

            A.CallTo(() => calculator.Divide(A<decimal>.Ignored, A<decimal>.Ignored)).Returns(100);

            Assert.AreEqual(100, calculator.Divide(1000, 10));
        }

        [TestMethod]
        [ExpectedException(typeof(DivideByZeroException))]
        public void DivideByZeroException()
        {
            var calculator = A.Fake<ICalculator>();

            A.CallTo(() => calculator.Divide(A<decimal>.Ignored, 0)).Throws(new DivideByZeroException());

            calculator.Divide(1000, 0);
        }

        [TestMethod]
        public void Multiply()
        {
            var calculator = A.Fake<ICalculator>();

            A.CallTo(() => calculator.Multiply(A<decimal>.Ignored, A<decimal>.Ignored)).Returns(100);

            Assert.AreEqual(100, calculator.Multiply(5, 20));
        }

        [TestMethod]
        public void Subtract()
        {
            var calculator = A.Fake<ICalculator>();

            A.CallTo(() => calculator.Subtract(A<decimal>.Ignored, A<decimal>.Ignored)).Returns(100);

            Assert.AreEqual(100, calculator.Subtract(150, 50));
        }

        [TestMethod]
        public void Sum()
        {
            var calculator = A.Fake<ICalculator>();

            A.CallTo(() => calculator.Sum(A<decimal>.Ignored, A<decimal>.Ignored)).Returns(100);

            Assert.AreEqual(100, calculator.Sum(40, 60));
        }

        [TestMethod]
        public void SumParameters()
        {
            var calculator = A.Fake<ICalculator>();

            A.CallTo(() => calculator.Sum(0, 0)).Returns(0);

            A.CallTo(() => calculator.Sum(40, 60)).Returns(100);

            Assert.AreEqual(0, calculator.Sum(0, 0));

            Assert.AreEqual(100, calculator.Sum(40, 60));
        }
    }
}
