using System;
using System.Collections;

namespace EbookBuilder
{
    /// <summary>
    /// An individual page, part of the ebook
    /// </summary>
    [Serializable]
    public class Page : Item
    {
        /// <summary>
        /// The index of the file. Used for building output in the correct order.
        /// </summary>
        public int Index;

        /// <summary>
        /// The type of item this is (Hint: It's a page!)
        /// </summary>
        public override ItemType Type { get { return ItemType.Page; } }

        /// <summary>
        /// The html content of the file. All datasources must provide a string value.
        /// </summary>
        public string Content;

        /// <summary>
        /// The name that generated the source
        /// </summary>
        public string SourceName;
    }
}
