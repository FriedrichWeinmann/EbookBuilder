using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EbookBuilder
{
    /// <summary>
    /// What kind of item it is
    /// </summary>
    public enum ItemType
    {
        /// <summary>
        /// A page filled with textto be displayed
        /// </summary>
        Page,

        /// <summary>
        /// An image resource used in a page
        /// </summary>
        Image
    }
}
