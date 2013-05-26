
String[] getFileNames(String dir, String ext) {
  String thisdir = sketchPath + "\\data\\" + dir;
  File file = new File(thisdir);
  String[] raw_names = file.list();


  int count = 0;
  for (int i = 0; i < raw_names.length; i++) {
    String[] parts = raw_names[i].split("\\.(?=[^\\.]+$)");
    if (parts[parts.length - 1].equals(ext) == true) count++;
  }

  String[] file_names = new String [count];
  count = 0;
  for (int i = 0; i < raw_names.length; i++) {
    String[] parts = raw_names[i].split("\\.(?=[^\\.]+$)");
    if (parts[parts.length - 1].equals(ext) == true) {
      file_names[count] = thisdir + "\\" + raw_names[i];
      count++;
    }
  }

  return file_names;
}

