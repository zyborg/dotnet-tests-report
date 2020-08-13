using System;
using System.Collections.Generic;

namespace Data
{
	public class Order
	{
		public Customer Customer { get; set; }

		public DateTime Date { get; set; }

		public int Id { get; set; }

		public IList<OrderItem> Items { get; set; }
	}
}
