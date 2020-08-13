using Data;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using System;

namespace MSTest
{
    [TestClass]
    public class MoqTest
    {
        [TestMethod]
        public void Divide()
        {
            var calculator = new Mock<ICalculator>();

            calculator.Setup(x => x.Divide(It.IsAny<decimal>(), It.IsAny<decimal>())).Returns(100);

            Assert.AreEqual(100, calculator.Object.Divide(1000, 10));
        }

        [TestMethod]
        [ExpectedException(typeof(DivideByZeroException))]
        public void DivideByZeroException()
        {
            var calculator = new Mock<ICalculator>();

            calculator.Setup(x => x.Divide(It.IsAny<decimal>(), 0)).Throws(new DivideByZeroException());

            calculator.Object.Divide(1000, 0);
        }

        [TestMethod]
        public void Multiply()
        {
            var calculator = new Mock<ICalculator>();

            calculator.Setup(x => x.Multiply(It.IsAny<decimal>(), It.IsAny<decimal>())).Returns(100);

            Assert.AreEqual(100, calculator.Object.Multiply(5, 20));
        }

        [TestMethod]
        public void Subtract()
        {
            var calculator = new Mock<ICalculator>();

            calculator.Setup(x => x.Subtract(It.IsAny<decimal>(), It.IsAny<decimal>())).Returns(100);

            Assert.AreEqual(100, calculator.Object.Subtract(150, 50));
        }

        [TestMethod]
        public void Sum()
        {
            var calculator = new Mock<ICalculator>();

            calculator.Setup(x => x.Sum(It.IsAny<decimal>(), It.IsAny<decimal>())).Returns(100);

            Assert.AreEqual(100, calculator.Object.Sum(40, 60));
        }

        [TestMethod]
        public void SumParameters()
        {
            var calculator = new Mock<ICalculator>();

            calculator.Setup(x => x.Sum(0, 0)).Returns(0);

            calculator.Setup(x => x.Sum(40, 60)).Returns(100);

            Assert.AreEqual(0, calculator.Object.Sum(0, 0));

            Assert.AreEqual(100, calculator.Object.Sum(40, 60));
        }
    }
}
