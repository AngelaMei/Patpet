#if UNITY_EDITOR
using System.IO;
using System.Xml.Linq;
using UnityEditor;
using UnityEngine;

namespace Auki.Manna.Editor
{
    [InitializeOnLoad]
    public static class Build
    {
        private const string AssemblyName = "Auki.QR";

        static Build()
        {
            var linkXmlDoc = File.Exists("Assets/link.xml") ? XDocument.Load("Assets/link.xml") : new XDocument();

            var root = linkXmlDoc.Element("linker");
            if (root == null)
            {
                root = new XElement("linker");
                linkXmlDoc.Add(root);
            }

            var assemblyElements = root.Elements("assembly");
            foreach (var item in assemblyElements)
            {
                if (item.FirstAttribute.Name == "fullname")
                {
                    if (item.FirstAttribute.Value.Equals(AssemblyName))
                    {
                        return;
                    }
                }
            }

            var assemblyElement = new XElement("assembly");
            assemblyElement.Add(new XAttribute("fullname", AssemblyName));
            assemblyElement.Add(new XAttribute("preserve", "all"));
            root.Add(assemblyElement);
            linkXmlDoc.Save("Assets/link.xml");

            Debug.Log($"{AssemblyName} added to link.xml");
        }
    }
}

#endif