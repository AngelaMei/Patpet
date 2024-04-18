#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor.Android;
using UnityEngine;

namespace Auki.Ur
{

    public class AndroidPostBuildProcessor : IPostGenerateGradleAndroidProject {
        public int callbackOrder {
            get {
                return 998;
            }
        }

        private enum LineOp
        {
            ToAddAfter,
            ToAddBefore,
            ToReplace
        }

        void IPostGenerateGradleAndroidProject.OnPostGenerateGradleAndroidProject(string unityLibrary_path)
        {
            Debug.Log("Ur Build unityLibrary_path: " + unityLibrary_path);

            // Refer to here to understand what is being modified and why:
            // https://docs.unity3d.com/Manual/android-gradle-overview.html
            List<string> fileContent;

            //gradle.properties
            string root_gradle_properties_File = unityLibrary_path.Replace("unityLibrary", "") + "gradle.properties";
            Debug.Log("Root gradle.properties file expected in: " + root_gradle_properties_File);
            if (!File.Exists(root_gradle_properties_File))
            {
                Debug.LogWarning("/gradle.properties file not found. Generating one from scratch. Check android settings.");
                StreamWriter writer = File.CreateText(root_gradle_properties_File);
                writer.WriteLine();
                writer.Flush();
                writer.Close();
            }
            fileContent = File.ReadAllLines(root_gradle_properties_File).ToList();
            SetProp(ref fileContent, "android.useAndroidX", "true");
            File.WriteAllLines(root_gradle_properties_File, fileContent);
            Debug.Log("Root gradle.properties file done.");

            //unityLibrary/build.gradle
            string unityLibrary_build_gradle_File = unityLibrary_path + "/build.gradle";
            Debug.Log("unityLibrary/build.gradle file expected in: " + unityLibrary_build_gradle_File);
            if (File.Exists(unityLibrary_build_gradle_File))
            {
                fileContent = File.ReadAllLines(unityLibrary_build_gradle_File).ToList();
                AddDependency(ref fileContent, "implementation 'com.google.flogger:flogger:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.code.findbugs:jsr305:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.flogger:flogger-system-backend:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.code.findbugs:jsr305:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.guava:guava:27.0.1-android'");
                AddDependency(ref fileContent, "implementation 'com.google.protobuf:protobuf-javalite:3.19.1'");
                AddDependency(ref fileContent, "implementation 'com.google.android.datatransport:transport-api:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.android.datatransport:transport-backend-cct:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.android.datatransport:transport-runtime:latest.release'");
                AddDependency(ref fileContent, "implementation 'com.google.auto.value:auto-value-annotations:1.8.1'");
                AddDependency(ref fileContent, "implementation 'com.google.auto.value:auto-value:1.8.1'");
                File.WriteAllLines(unityLibrary_build_gradle_File, fileContent);
            }
            else
            {
                throw new Exception("/unityLibrary/build.gradle file not found!");
            }
            Debug.Log("unityLibrary/build.gradle file done.");
        }

        private void SetProp(ref List<string> lines, string prop, string value)
        {
            if (IsStringAlreadyPresent(lines, prop))
            {
                // if present, check if also value coincides
                AddManualLine(ref lines, prop+"="+value, LineOp.ToReplace, prop);
            }
            else
            {
                // if not present, append
                AddManualLine(ref lines, prop+"="+value, LineOp.ToAddAfter);
            }
        }

        private void AddDependency(ref List<string> lines, string dependency)
        {
            if (!IsStringAlreadyPresent(lines, dependency))
                AddManualLine(ref lines, dependency, LineOp.ToAddAfter, "dependencies");
        }

        private bool IsStringAlreadyPresent(List<string> lines, string toFind)
        {
            // scan file if 'toFind' is already present
            foreach (string line in lines)
            {
                if (line.Contains(toFind, StringComparison.InvariantCultureIgnoreCase))
                    return true;
            }
            return false;
        }

        private void AddManualLine(ref List<string> lines, string toInsert, LineOp operation, string what = "")
        {
            int locationIndex = 0;
            bool isWhatSpecified = !string.IsNullOrWhiteSpace(what);

            // default to 'ToAddAfter' when no 'what' is specified, appends to end of file
            if (!isWhatSpecified && operation == LineOp.ToReplace)
                operation = LineOp.ToAddAfter;

            // looking for something specific?
            if (isWhatSpecified)
            {
                // move to line containing 'what'
                for (locationIndex = 0; locationIndex < lines.Count; locationIndex++)
                {
                    if (lines[locationIndex].Contains(what, StringComparison.InvariantCultureIgnoreCase))
                        break;
                }
                if (locationIndex == lines.Count)
                    throw new Exception("Line '" + what + "' not found!");
            }

            switch (operation)
            {
                case LineOp.ToAddAfter: // insert right after given line
                    if (isWhatSpecified)
                        lines.Insert(locationIndex+1, toInsert);
                    else
                        lines.Insert(lines.Count, toInsert);    // no what given, append to end of file
                    break;
                case LineOp.ToAddBefore: // insert right before given line
                    lines.Insert(locationIndex, toInsert);
                    break;
                case LineOp.ToReplace:  // replace
                    lines.RemoveAt(locationIndex);
                    goto case LineOp.ToAddBefore;
                default:
                    throw new ArgumentOutOfRangeException(nameof(operation), operation, null);
            }
        }
    }

}

#endif