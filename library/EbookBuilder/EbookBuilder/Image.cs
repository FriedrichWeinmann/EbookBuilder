using System;

namespace EbookBuilder
{
    /// <summary>
    /// An image used in the ebook
    /// </summary>
    public class Image : Item
    {
        /// <summary>
        /// The ID of the image (used to link it to the page)
        /// </summary>
        public Guid ImageID = Guid.NewGuid();

        /// <summary>
        /// The extension of the image
        /// </summary>
        public string Extension;

        /// <summary>
        /// Extension of the file to write the image to.
        /// </summary>
        public string FileName
        {
            get { return String.Format("{0}.{1}", ImageID, Extension); }
        }

        /// <summary>
        /// The type of item this is (Hint: It's an Image!)
        /// </summary>
        public override ItemType Type { get { return ItemType.Image; } }

        /// <summary>
        /// The actual image data
        /// </summary>
        public byte[] Data;
    }
}
