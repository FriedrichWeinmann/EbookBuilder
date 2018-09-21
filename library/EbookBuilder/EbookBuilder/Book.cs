using System;
using System.Collections;
using System.Collections.Generic;

namespace EbookBuilder
{
    /// <summary>
    /// The entire book, combining 
    /// </summary>
    [Serializable]
    public class Book
    {
        /// <summary>
        /// The name of the book
        /// </summary>
        public string Name;

        /// <summary>
        /// Name of the author
        /// </summary>
        public string Author;

        /// <summary>
        /// Name of the publisher
        /// </summary>
        public string Publisher;

        /// <summary>
        /// The pages that make up the book
        /// </summary>
        public List<Page> Pages = new List<Page>();

        /// <summary>
        /// The CSS File to use to style the book
        /// </summary>
        public Page CssFile;

        /// <summary>
        /// The timestamp of when the book was assembled
        /// </summary>
        public DateTime TimeCreated;

        /// <summary>
        /// Additional metadata of the book
        /// </summary>
        public Hashtable Metadata = new Hashtable(StringComparer.InvariantCultureIgnoreCase);
    }
}
