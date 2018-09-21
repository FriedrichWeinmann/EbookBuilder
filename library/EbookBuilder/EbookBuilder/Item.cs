using System;
using System.Collections;

namespace EbookBuilder
{
    /// <summary>
    /// Base class for all items that can go into an ebook
    /// </summary>
    public abstract class Item
    {
        /// <summary>
        /// Name of the item
        /// </summary>
        public string Name;

        /// <summary>
        /// The type of item it is
        /// </summary>
        public abstract ItemType Type { get; }

        /// <summary>
        /// The timestamp the item was recorded from source
        /// </summary>
        public DateTime TimeCreated;

        /// <summary>
        /// Additional metadata a source can freely add
        /// </summary>
        public Hashtable MetaData = new Hashtable(StringComparer.InvariantCultureIgnoreCase);
    }
}
