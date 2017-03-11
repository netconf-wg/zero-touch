#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/x509.h>

// forward declarations
int packit(char* input_file, char* output_file);
int unpackit(char* input_file, char* output_file);

int main (int argc, char **argv) {

  int unpack_flag = 0;
  char input_file[256] = "";
  char output_file[256] = "";
  int c;

  while ((c = getopt (argc, argv, "i:o:r")) != -1) {
    switch (c) {
      case 'i':
        strlcpy(input_file, optarg, sizeof(input_file));
        break;
      case 'o':
        strlcpy(output_file, optarg, sizeof(output_file));
        break;
      case 'r':
        unpack_flag = 1;
        break;
      case '?':
        break;
      default:
        exit(1);
    }
  }

  if (!strlen(input_file) || !strlen(output_file)) {
    printf("Wraps passed file into a pkcs7 structure (-r reverses the operation)\n");
    printf("\n");
    printf("Usage: %s [-r] -i <input> -o <output>\n", argv[0]);
    printf("\n");
    printf("  -r: reverses the operation...\n");
    printf("  -i: the input filename\n");
    printf("  -o: the outout filename\n");
    printf("\n");
    exit(1);
  }


  if (unpack_flag == 0) {
    if (!packit(input_file, output_file)) {
      printf("fatal error.\n");
      exit(1);
    }
  } else {
    if (!unpackit(input_file, output_file)) {
      printf("fatal error.\n");
      exit(1);
    }
  }

  exit (0);
}



int packit(char* input_file, char* output_file) {
  BIO* bio_err = NULL;
  BIO* input_bio = NULL;
  BIO* output_bio = NULL;
  PKCS7* p7 = NULL;
  int ret = -1;

  if ((bio_err = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    exit(1);
  }
  BIO_set_fp(bio_err, stderr, BIO_NOCLOSE | BIO_FP_TEXT);

  if ((input_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(input_bio, input_file) <= 0) {
    printf("error opening the file, %s\n", input_file);
    return 0;
  }



  p7 = PKCS7_sign(NULL, NULL, NULL, input_bio, PKCS7_BINARY);


/*
  if ((p7 = PKCS7_new()) == NULL) {
    printf("PKCS7_new() failed\n");
    goto end;
  }
  p7->type = OBJ_nid2obj(NID_pkcs7_signed);
  p7->d.sign = PKCS7_SIGNED_new();
  if (p7->d.sign == NULL) {
    printf("PKCS7_SIGNED_new() failed\n");
    goto end;
  }
  p7->d.sign->contents->type = OBJ_nid2obj(NID_pkcs7_data);
  if (!ASN1_INTEGER_set(p7->d.sign->version, 1)) {
    printf("ASN1_INTEGER_set(p7s->version, 1) failed\n");
    goto end;
  }
*/



  if ((output_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_write_filename(output_bio, output_file) <= 0) {
    printf("BIO_write_filename(output_bio, output_file) failed\n");
    goto end;
  }

  if (i2d_PKCS7_bio(output_bio, p7) == 0) {
    BIO_printf(bio_err, "unable to write pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  ret = 1;

end:

  if (input_bio != NULL)
    BIO_free(input_bio);
  if (output_bio != NULL)
    BIO_free(output_bio);

  return ret;
}



int unpackit(char* input_file, char* output_file) {
  BIO* bio_err = NULL;
  BIO* input_bio = NULL;
  BIO* output_bio = NULL;
  PKCS7* p7 = NULL;
  int ret = -1;

  if ((bio_err = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    exit(1);
  }
  BIO_set_fp(bio_err, stderr, BIO_NOCLOSE | BIO_FP_TEXT);

  if ((input_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_read_filename(input_bio, input_file) <= 0) {
    printf("error opening the file, %s\n", input_file);
    return 0;
  }

  if (d2i_PKCS7_bio(input_bio, &p7) == 0) {
    BIO_printf(bio_err, "unable to read pkcs7 object\n");
    ERR_print_errors(bio_err);
    goto end;
  }

  assert(OBJ_obj2nid(p7->type) == NID_pkcs7_signed);
  assert(p7->d.sign != NULL);
  assert(ASN1_INTEGER_get(p7->d.sign->version) == 1);
  assert(p7->d.sign->crl == NULL);
  assert(OBJ_obj2nid(p7->d.sign->contents->type) == NID_pkcs7_data);
  //printf("data.length = %d\n", p7->d.sign->contents->d.data->length);
  //printf("data.data = %s\n", p7->d.sign->contents->d.data->data);

  if ((output_bio = BIO_new(BIO_s_file())) == NULL) {
    printf("BIO_new(BIO_s_file()) failed\n");
    return 0;
  }

  if (BIO_write_filename(output_bio, output_file) <= 0) {
    printf("BIO_write_filename(output_bio, output_file) failed\n");
    goto end;
  }

  if (BIO_write(output_bio, p7->d.sign->contents->d.data->data, p7->d.sign->contents->d.data->length) == 0) {
    printf("BIO_write(output_bio, data, length) failed\n");
    goto end;
  }

  ret = 1;

end:

  if (input_bio != NULL)
    BIO_free(input_bio);
  if (output_bio != NULL)
    BIO_free(output_bio);

  return ret;
}


