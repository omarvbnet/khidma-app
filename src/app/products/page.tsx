"use client";
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { Search } from '@/components/ui/Search';
import { useSearchParams } from 'next/navigation';
import { PlusIcon } from '@heroicons/react/24/outline';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
}

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const searchParams = useSearchParams();

  useEffect(() => {
    fetchProducts();
  }, [searchParams]);

  const fetchProducts = async () => {
    const query = searchParams.get('query') || '';
    setLoading(true);
    try {
      const res = await fetch(`/api/products?query=${query}`);
      const data = await res.json();
      setProducts(data);
    } catch (error) {
      console.error('Error fetching products:', error);
    }
    setLoading(false);
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this product?')) return;
    setDeletingId(id);
    try {
      const res = await fetch(`/api/products/${id}`, {
        method: 'DELETE',
      });
      if (res.ok) {
        setProducts(products.filter(product => product.id !== id));
      } else {
        alert('Failed to delete product');
      }
    } catch (error) {
      alert('An error occurred while deleting the product');
    }
    setDeletingId(null);
  };

  if (loading) {
    return (
      <div className="py-12">
        <div className="animate-pulse max-w-4xl mx-auto">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="page-header">
        <div>
          <h1 className="page-title">Products</h1>
          <p className="page-description">
            Manage your product catalog and inventory.
          </p>
        </div>
        <div className="flex w-full sm:w-auto gap-2">
          <Search placeholder="Search by name or description..." />
          <Link href="/products/create" className="btn-primary">
            <PlusIcon className="h-5 w-5 mr-2" />
            Create Product
          </Link>
        </div>
      </div>

      <div className="table-container">
        <table className="table">
          <thead className="table-header">
            <tr>
              <th scope="col" className="table-header-cell">Name</th>
              <th scope="col" className="table-header-cell">Price</th>
              <th scope="col" className="table-header-cell">Category</th>
              <th scope="col" className="table-header-cell">Stock</th>
              <th scope="col" className="table-header-cell">Status</th>
              <th scope="col" className="table-header-cell">Actions</th>
            </tr>
          </thead>
          <tbody className="table-body">
            {products.map((product) => (
              <tr key={product.id} className="table-row">
                <td className="table-cell">{product.name}</td>
                <td className="table-cell">${product.price.toFixed(2)}</td>
                <td className="table-cell">Category</td>
                <td className="table-cell">100</td>
                <td className="table-cell">
                  <span className="badge badge-success">In Stock</span>
                </td>
                <td className="table-cell">
                  <div className="flex items-center gap-2">
                    <Link
                      href={`/products/${product.id}/edit`}
                      className="btn-secondary"
                    >
                      Edit
                    </Link>
                    <button
                      onClick={() => handleDelete(product.id)}
                      disabled={deletingId === product.id}
                      className="btn-danger"
                    >
                      {deletingId === product.id ? 'Deleting...' : 'Delete'}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
} 