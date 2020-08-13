using Data;
using FizzWare.NBuilder;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MSTest
{
    [TestClass]
    public class NBuilderTest
    {
        [TestMethod]
        public void Builder()
        {
            var order = Builder<Order>.CreateNew().Build();

            order.Customer = Builder<Customer>.CreateNew().Build();

            var products = Builder<Product>.CreateListOfSize(500).Build();

            order.Items = Builder<OrderItem>
                .CreateListOfSize(5)
                .All()
                .With(item => item.Order = order)
                .With(item => item.Product = Pick<Product>.RandomItemFrom(products))
                .Build();

            Assert.IsNotNull(order);

            Assert.IsTrue(order.Items.Count == 5);
        }
    }
}
