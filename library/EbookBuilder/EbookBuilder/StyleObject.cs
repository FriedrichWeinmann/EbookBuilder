using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EbookBuilder
{
    /// <summary>
    /// Represents all CSS style settings associated with a given tag or class
    /// </summary>
    public class StyleObject
    {
        /// <summary>
        /// Tag this style affects
        /// </summary>
        public string Tag;

        /// <summary>
        /// Class this style affects
        /// </summary>
        public string Class;

        /// <summary>
        /// Attributes that are part of this style object
        /// </summary>
        public Dictionary<string, string> Attributes = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Creates the default style string display
        /// </summary>
        /// <returns>The default string representation of this style</returns>
        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(Class);
            if (!String.IsNullOrEmpty(Tag))
                sb.Append($".{Tag}");
            sb.Append($" ({Attributes.Count})");
            return sb.ToString();
        }

        /// <summary>
        /// Present the style as an inline attribute to be placed inside the opening html tag.
        /// </summary>
        /// <param name="Header">Whether to include the header part of the style attribute (adds the 'style="' and '"' parts around the compacted attributes.</param>
        /// <returns>The inline attribute for use within the html tag</returns>
        public string ToInline(bool Header = false)
        {
            StringBuilder sb = new StringBuilder();
            bool first = true;
            if (Header)
                sb.Append("style=\"");

            foreach (var entry in Attributes)
            {
                if (first)
                {
                    sb.AppendFormat("{0}: {1};", entry.Key, entry.Value);
                    first = false;
                }
                else
                    sb.AppendFormat(" {0}: {1};", entry.Key, entry.Value);
            }

            if (Header)
                sb.Append("\"");
            return sb.ToString();
        }

        /// <summary>
        /// Present the style as it would be used within a CSS stylesheet
        /// </summary>
        /// <returns>The style as it would be used within a CSS stylesheet</returns>
        public string ToStyleSheet()
        {
            StringBuilder sb = new StringBuilder();

            if (Tag != "")
                sb.Append(Tag);
            if (Class != "")
                sb.Append(Class);
            sb.AppendLine(" {");

            foreach (var entry in Attributes)
                sb.AppendLine($"    {entry.Key}: {entry.Value};");

            sb.AppendLine("}");
            return sb.ToString();
        }
    }
}
