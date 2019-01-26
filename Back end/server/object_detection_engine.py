import sysv_ipc
import cv2
import numpy as np
import sys
import os
import six.moves.urllib as urllib
import sys
import tarfile
import tensorflow as tf
import zipfile
from collections import defaultdict
from io import StringIO
import matplotlib 
from PIL import Image
import struct

image_counter = 1

class BoundingBox():
  def __init__(self, coordinate_array, prediction, score):
    self.y_min = format(coordinate_array[0], '.4f')
    self.x_min = format(coordinate_array[1], '.4f')
    self.y_max = format(coordinate_array[2], '.4f')
    self.x_max = format(coordinate_array[3], '.4f')
    self.prediction = int(prediction)
    self.score = format(score, '.4f')
  def description(self):
    return self.y_min + ":" + self.x_min + ":" + self.y_max + ":" + self.x_max + ":" + str(self.prediction) + ":" + self.score + "-" 

# This is needed since the notebook is stored in the object_detection folder.
sys.path.append("..")
from object_detection.utils import ops as utils_ops

if tf.__version__ < '1.4.0':
  raise ImportError('Please upgrade your tensorflow installation to v1.4.* or later!')

# This is needed to display the images.
# %matplotlib inline

from utils import label_map_util
from utils import visualization_utils as vis_util

# What model to download.
MODEL_NAME = '29_05_exported_model_v1/'
# Path to frozen detection graph. This is the actual model that is used for the object detection.
PATH_TO_CKPT = MODEL_NAME + '/frozen_inference_graph.pb'

# List of the ngs that is used to add correct label for each box.
PATH_TO_LABELS = os.path.join('../', 'object-detection.pbtxt')

NUM_CLASSES = 1

detection_graph = tf.Graph()
with detection_graph.as_default():
  od_graph_def = tf.GraphDef()
  with tf.gfile.GFile(PATH_TO_CKPT, 'rb') as fid:
    serialized_graph = fid.read()
    od_graph_def.ParseFromString(serialized_graph)
    tf.import_graph_def(od_graph_def, name='')

label_map = label_map_util.load_labelmap(PATH_TO_LABELS)
categories = label_map_util.convert_label_map_to_categories(label_map, max_num_classes=NUM_CLASSES, use_display_name=True)
category_index = label_map_util.create_category_index(categories)

def load_image_into_numpy_array(image):
  (im_width, im_height) = image.size
  return np.array(image.getdata()).reshape(
      (im_height, im_width, 3)).astype(np.uint8)

# For the sake of simplicity we will use only 2 images:
# image1.jpg
# image2.jpg
# If you want to test the code with your images, just add path to the images to the TEST_IMAGE_PATHS.
# Size, in inches, of the output images.
IMAGE_SIZE = (12, 8)

# init state
image_shared_memory_id = 12345666
image_shared_memory = sysv_ipc.SharedMemory(image_shared_memory_id)

image_ready_shared_memory_id = 1234567
image_ready_shared_memory = sysv_ipc.SharedMemory(image_ready_shared_memory_id)

bounding_boxes_ready_shared_memory_id = 12345678
bounding_boxes_ready_shared_memory = sysv_ipc.SharedMemory(bounding_boxes_ready_shared_memory_id)

bounding_boxes_shared_memory_id = 12345678910
bounding_boxes_shared_memory = sysv_ipc.SharedMemory(bounding_boxes_shared_memory_id)

bounding_boxes_string_size_shared_memory_id = 1234566677
bounding_boxes_string_size_shared_memory = sysv_ipc.SharedMemory(bounding_boxes_string_size_shared_memory_id)

def read_image():
  # Read value from shared memory
  memory_value = image_shared_memory.read()
  # create bytesarray to hold image_data
  file_bytes = np.asarray(bytearray(memory_value), dtype=np.uint8)
  image = file_bytes.reshape((300, 300, 3))
  return image

def wait_for_image():
  # read shared memory for the value
  is_image_ready = int.from_bytes(image_ready_shared_memory.read(), byteorder=sys.byteorder)
  while is_image_ready != 1:
    is_image_ready = int.from_bytes(image_ready_shared_memory.read(), byteorder=sys.byteorder)
  return

def write_bounding_boxes_to_shared_memory(bounding_boxes):
  bounding_boxes_shared_memory.write(bounding_boxes)

def set_bounding_boxes_ready_flag(status):
  bounding_boxes_ready_shared_memory.write((status).to_bytes(4, byteorder=sys.byteorder))

def set_image_ready_flag(status):
  image_ready_shared_memory.write((status).to_bytes(4, byteorder=sys.byteorder))

def write_bounding_boxes_string_size_to_shared_memory(size):
  bounding_boxes_string_size_shared_memory.write(struct.pack('i', size))

def display_image(image):
  cv2.imshow('image', image)
  if cv2.waitKey(1) & 0xFF == ord('q'):
    return

def object_detection(image_np, detection_graph, sess):
  # Expand dimensions since the model expects images to have shape: [1, None, None, 3]
  image_np_expanded = np.expand_dims(image_np, axis=0)
  image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')
  # Each box represents a part of the image where a particular object was detected.
  boxes = detection_graph.get_tensor_by_name('detection_boxes:0')
  # Each score represent how level of confidence for each of the objects.
  # Score is shown on the result image, together with the class label.
  scores = detection_graph.get_tensor_by_name('detection_scores:0')
  classes = detection_graph.get_tensor_by_name('detection_classes:0')
  num_detections = detection_graph.get_tensor_by_name('num_detections:0')
  # Actual detection.
  (boxes, scores, classes, num_detections) = sess.run(
      [boxes, scores, classes, num_detections],
      feed_dict={image_tensor: image_np_expanded})
  bounding_boxes = ""
  for i in range(len(scores[0])):
    if scores[0][i] > 0.5:
      bounding_box = BoundingBox(boxes[0][i], classes[0][i], scores[0][i])
      bounding_boxes += bounding_box.description()
  # Visualization of the results of a detection.
  print(bounding_boxes)
  vis_util.visualize_boxes_and_labels_on_image_array(
      image_np,
      np.squeeze(boxes),
      np.squeeze(classes).astype(np.int32),
      np.squeeze(scores),
      category_index,
      use_normalized_coordinates=True,
      line_thickness=8)
  cv2.imwrite('logImages/' + str(image_counter) + '.jpg',image_np)
  image_counter += 1
  return (image_np, bounding_boxes)

# run this process indefinetly
with detection_graph.as_default():
  with tf.Session(graph=detection_graph) as sess:
    while True:
      wait_for_image()
      image = read_image()
      (image_od, bounding_boxes) = object_detection(image, detection_graph, sess)
      # display_image(image_od)
      write_bounding_boxes_to_shared_memory(bounding_boxes)
      print("bounding box string size is: " + str(sys.getsizeof(bounding_boxes)))
      write_bounding_boxes_string_size_to_shared_memory(sys.getsizeof(bounding_boxes))
      set_bounding_boxes_ready_flag(1)
      set_image_ready_flag(0)