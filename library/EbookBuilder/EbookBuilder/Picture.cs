using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace EbookBuilder
{
    /// <summary>
    /// A picture to be included in an ebook.
    /// Uses humanized labels, rather than cryptic but guaranteed unique IDs.
    /// </summary>
    public class Picture : Item
    {
        /// <summary>
        /// The name of the file
        /// </summary>
        public string DisplayName;

        /// <summary>
        /// The ID of the image (used to link it to the page)
        /// </summary>
        public string ImageID
        {
            get { return DisplayName; }
        }

        /// <summary>
        /// The extension of the image
        /// </summary>
        public string Extension;

        /// <summary>
        /// Extension of the file to write the image to.
        /// </summary>
        public string FileName
        {
            get { return DisplayName; }
        }

        /// <summary>
        /// The type of item this is (Hint: It's an Image!)
        /// </summary>
        public override ItemType Type { get { return ItemType.Image; } }

        /// <summary>
        /// The actual image data
        /// </summary>
        public byte[] Data;

        /// <summary>
        /// Create a new picture object from its fileinfo object.
        /// </summary>
        /// <param name="Info">The object describing the file to load</param>
        /// <returns>A completed picture object for use in ebook creation.</returns>
        public static Picture GetPicture(FileInfo Info)
        {
            Picture result = new Picture();
            result.TimeCreated = Info.CreationTime;
            result.Name = Info.Name;
            result.DisplayName = Info.Name;
            result.Extension = Info.Extension;
            result.Data = File.ReadAllBytes(Info.FullName);
            return result;
        }
    }
}
