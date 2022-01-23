import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.applications import vgg19
base_image_path = keras.utils.get_file("asterix.jpg", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0mVEQDMv_EuGoo-pipxCyfZ363gWBIMNJdQ&usqp=CAU")
style_reference_image_path = keras.utils.get_file("acrylic1.jpg", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShk1CxMLN7K0kE9RWx3CxckfUaP8295Mcw1w&usqp=CAU")
result_prefix = "paris_generated"

# Wagi różnych składników strat 
total_variation_weight = 1e-6
style_weight = 1e-6
content_weight = 2.5e-5

# Wymiary wygenerowanego obrazu. 
width, height = keras.preprocessing.image.load_img(base_image_path).size
img_nrows = 300
img_ncols = int(width * img_nrows / height)

from IPython.display import Image, display

display(Image(base_image_path))
display(Image(style_reference_image_path))

def preprocess_image(image_path):
    # Użyj funkcji do otwierania, zmiany rozmiaru i formatowania zdjęć na odpowiednie tensory 
    img = keras.preprocessing.image.load_img(
        image_path, target_size=(img_nrows, img_ncols)
    )
    img = keras.preprocessing.image.img_to_array(img)
    img = np.expand_dims(img, axis=0)
    img = vgg19.preprocess_input(img)
    return tf.convert_to_tensor(img)

def deprocess_image(x):
    # Funkcja Util do konwersji tensora na prawidłowy obraz 
    x = x.reshape((img_nrows, img_ncols, 3))
    # Usuń środek zerowy za pomocą średniego piksela 
    x[:, :, 0] += 103.939
    x[:, :, 1] += 116.779
    x[:, :, 2] += 123.68
    # 'BGR'->'RGB'
    x = x[:, :, ::-1]
    x = np.clip(x, 0, 255).astype("uint8")
    return x

# Macierz gramowa tensora obrazu (produkt zewnętrzny ze względu na cechy) 
def gram_matrix(x):
    x = tf.transpose(x, (2, 0, 1))
    features = tf.reshape(x, (tf.shape(x)[0], -1))
    gram = tf.matmul(features, tf.transpose(features))
    return gram

# "style loss" ma na celu utrzymanie stylu obrazu referencyjnego w generowanym obrazie. 
# Opiera się na macierzach gramów (które rejestrują styl) 
# mapy funkcji z obrazu odniesienia stylu i z wygenerowanego obrazu 
def style_loss(style, combination):
    S = gram_matrix(style)
    C = gram_matrix(combination)
    channels = 3
    size = img_nrows * img_ncols
    return tf.reduce_sum(tf.square(S - C)) / (4.0 * (channels ** 2) * (size ** 2))

# Pomocnicza funkcja strat zaprojektowane w celu utrzymania „treści” obraz bazowy w wygenerowanym obrazie 
def content_loss(base, combination):
    return tf.reduce_sum(tf.square(combination - base))

# Trzecia funkcja straty, całkowita strata zmienności, zaprojektowane tak, aby wygenerowany obraz był lokalnie spójny 

def total_variation_loss(x):
    a = tf.square(
        x[:, : img_nrows - 1, : img_ncols - 1, :] - x[:, 1:, : img_ncols - 1, :]
    )
    b = tf.square(
        x[:, : img_nrows - 1, : img_ncols - 1, :] - x[:, : img_nrows - 1, 1:, :]
    )
    return tf.reduce_sum(tf.pow(a + b, 1.25))
  
  # Build a VGG19 model loaded with pre-trained ImageNet weights
model = vgg19.VGG19(weights="imagenet", include_top=False)

# Get the symbolic outputs of each "key" layer (we gave them unique names).
outputs_dict = dict([(layer.name, layer.output) for layer in model.layers])

# Set up a model that returns the activation values for every layer in
# VGG19 (as a dict).
feature_extractor = keras.Model(inputs=model.inputs, outputs=outputs_dict)

# Lista warstw używanych do utraty stylu. 
style_layer_names = [
    "block1_conv1",
    "block2_conv1",
    "block3_conv1",
    "block4_conv1",
    "block5_conv1",
]
# Warstwa używana do utraty zawartości. 
content_layer_name = "block5_conv2"


def compute_loss(combination_image, base_image, style_reference_image):
    input_tensor = tf.concat(
        [base_image, style_reference_image, combination_image], axis=0
    )
    features = feature_extractor(input_tensor)

    # Zainicjuj utratę
    loss = tf.zeros(shape=())

    # Dodaj utratę treści 
    layer_features = features[content_layer_name]
    base_image_features = layer_features[0, :, :, :]
    combination_features = layer_features[2, :, :, :]
    loss = loss + content_weight * content_loss(
        base_image_features, combination_features
    )
    # Dodaj utratę stylu 
    for layer_name in style_layer_names:
        layer_features = features[layer_name]
        style_reference_features = layer_features[1, :, :, :]
        combination_features = layer_features[2, :, :, :]
        sl = style_loss(style_reference_features, combination_features)
        loss += (style_weight / len(style_layer_names)) * sl

    # Dodaj całkowitą utratę zmienności 
    loss += total_variation_weight * total_variation_loss(combination_image)
    return loss

@tf.function
def compute_loss_and_grads(combination_image, base_image, style_reference_image):
    with tf.GradientTape() as tape:
        loss = compute_loss(combination_image, base_image, style_reference_image)
    grads = tape.gradient(loss, combination_image)
    return loss, grads
  
  optimizer = keras.optimizers.SGD(
    keras.optimizers.schedules.ExponentialDecay(
        initial_learning_rate=100.0, decay_steps=100, decay_rate=0.96
    )
)

base_image = preprocess_image(base_image_path)
style_reference_image = preprocess_image(style_reference_image_path)
combination_image = tf.Variable(preprocess_image(base_image_path))

iterations = 3000
for i in range(1, iterations + 1):
    loss, grads = compute_loss_and_grads(
        combination_image, base_image, style_reference_image
    )
    optimizer.apply_gradients([(grads, combination_image)])
    if i % 100 == 0:
        print("Iteration %d: loss=%.2f" % (i, loss))
        img = deprocess_image(combination_image.numpy())
        fname = result_prefix + "_at_iteration_%d.png" % i
        keras.preprocessing.image.save_img(fname, img)
        
display(Image(result_prefix + "_at_iteration_3000.png"))
